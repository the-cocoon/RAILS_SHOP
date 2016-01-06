# include RailsShop::StatesProcessing
module RailsShop
  module StatesProcessing
    extend ActiveSupport::Concern

    STATES = %w[ published draft deleted ]

    included do
      validates_inclusion_of :state, in: STATES

      scope :with_state,    ->(states){ where state: Array.wrap(states) }
      scope :for_manage,    ->{ with_state [:draft, :published] }
      scope :available_for, ->(user = nil) { user.admin? ? for_manage : published }

      scope :published,  ->{ with_state :published }
      scope :draft,      ->{ with_state :draft     }
      scope :deleted,    ->{ with_state :deleted   }

      after_save :prosess_state_changes

      STATES.each do |state|
        define_method "#{ state }?" do
          self.state.to_s == state.to_s
        end

        define_method "#{ state }!" do
          self.state = state
          save!
        end
      end

      private

      def prosess_state_changes
        return true unless state_changed?

        # basic life cicle
        if state_change == ['draft', 'published']
        end

        if state_change == ['published', 'draft']
        end

        # deliting
        if state_change == ['draft', 'deleted']
        end

        if state_change == ['published', 'deleted']
        end

        # restoring
        if state_change == ['deleted', 'draft']
        end

        if state_change == ['deleted', 'published']
        end
      end
    end # included

  end # StatesProcessing
end # RailsShop
