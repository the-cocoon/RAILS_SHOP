# include ::RailsShop::ContentProcessing
module RailsShop
  module ContentProcessing
    def content_processing_for current_user
      return unless current_user

      self.title   = title.squish.strip
      self.intro   = process_content(raw_intro,   current_user)
      self.content = process_content(raw_content, current_user)
    end

    def process_content txt, current_user
      al_helper = ::AutoLink.new

      txt = sanitize_for(txt, current_user)
      txt = txt.empty_p2br

      txt = al_helper.auto_link(txt, sanitize: false, html: { target: :_blank, rel: :nofollow })
      txt = txt.add_nofollow_to_links if !current_user.admin?
      txt = txt.wrap_nofollow_links_with_noindex

      txt.strip
    end

    def sanitize_for txt, current_user
      if current_user.admin?
        ::Sanitize.fragment(txt, Sanitize::Config::ADMIN_RELAXED)
      else
        ::Sanitize.fragment(txt, Sanitize::Config::BLOGGER_HTML)
      end
    end

  end
end

