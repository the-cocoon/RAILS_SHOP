# include RailsShop::OrderStates
module RailsShop
  module OrderStates
    extend ActiveSupport::Concern

    STATES = %w[ draft moderation ready_to_payment paid processing delivery completed refund deleted ]

    included do
      validates_inclusion_of :state, in: STATES

      scope :with_state, ->(states){ where(state: Array.wrap(states)) if states.present? }
      scope :for_manage, ->{ with_state STATES }
      scope :for_user,   ->{ with_state %w[ draft moderation ready_to_payment paid processing delivery completed ] }

      scope :active,  ->{ where "orders.created_at > ?", Time.zone.now - ::Order::EXPIRE_AFTER.hours }
      scope :expired, ->{ where "orders.created_at < ?", Time.zone.now - ::Order::EXPIRE_AFTER.hours }

      STATES.each do |state|
        scope state, ->{ with_state state }

        define_method "#{ state }?" do
          self.state.to_s == state.to_s
        end

        define_method "#{ state }!" do
          self.state = state
          save!
        end
      end

      def define_ready_to_payment!
        self.state = delivery.order_moderation_required ? :moderation : :ready_to_payment
        save!
      end

      def send_created_notification!
        # OrderMailer.delay_for(1.second).created(self.id)
        OrderMailer.created(self.id).deliver_now
      end

      def send_state_changes_notification!
        state_changes = previous_changes[:state]
        return false if state_changes.blank?

        order    = self
        order_id = order.id
        mailer   = OrderMailer

        # basic life cicle
        letter = case state_changes
          when ['draft', 'moderation']
            mailer.moderation(order_id)
          when ['draft', 'ready_to_payment']
            mailer.ready_to_payment(order_id)
          when ['moderation', 'ready_to_payment']
            mailer.ready_to_payment(order_id)
          when ['ready_to_payment', 'paid']
            mailer.paid(order_id)
          when ['paid', 'processing']
            mailer.processing(order_id)
          when ['delivery', 'completed']
            mailer.delivery(order_id)
          else
            mailer.unexpected_transition(order_id, order.state_change)
        end

        letter.deliver_now

        true
      end # process_state_changes

    end # included
  end # StatesProcessing
end # RailsShop
