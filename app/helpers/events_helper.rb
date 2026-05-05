# frozen_string_literal: true

require "cgi"

module EventsHelper
  def events_nav(event = @event, selected: nil)
    items = []

    if policy(event).activation_flow?
      items << {
        name: "Activate",
        path: event_activation_flow_path(event_id: event.slug),
        tooltip: "Activate this organization",
        icon: "checkmark",
        selected: selected == :activation_flow,
        adminTool: true,
      }
    end

    if policy(event).show?
      items << {
        name: "Home",
        path: event_path(id: event.slug),
        tooltip: "See everything at-a-glance",
        icon: "home",
        selected: selected == :home,
      }
    end

    if policy(event).announcement_overview?
      items << {
        name: "Announcements",
        path: event_announcement_overview_path(event_id: event.slug),
        tooltip: "View your announcements",
        icon: "announcement",
        selected: selected == :announcements,
      }
    end

    if policy(event).transactions?
      items << {
        name: "Transactions",
        path: event_transactions_path(event_id: event.slug),
        tooltip: "View detailed ledger",
        icon: "bank-account",
        selected: selected == :transactions,
      }
    end

    if policy(event).account_number?
      items << {
        name: "Account numbers",
        path: account_number_event_path(event),
        tooltip: "View account numbers",
        icon: "hashtag",
        selected: selected == :account_number,
      }
    end

    if policy(event).donation_overview? || policy(event).invoices? || policy(event.check_deposits.build).index?
      items << { section: "Receive" }
    end

    if policy(event).donation_overview?
      items << {
        name: "Donations",
        path: event_donation_overview_path(event_id: event.slug),
        tooltip: "Support this organization",
        icon: "support",
        data: { tour_step: "donations" },
        selected: selected == :donations,
      }
    end

    if policy(event).invoices?
      items << {
        name: "Invoices",
        path: event_invoices_path(event_id: event.slug),
        tooltip: "Collect sponsor payments",
        icon: "payment-docs",
        selected: selected == :invoices,
      }
    end

    if policy(event.check_deposits.build).index?
      items << {
        name: "Check deposits",
        path: event_check_deposits_path(event),
        tooltip: "Deposit a check",
        icon: "cheque",
        selected: selected == :deposit_check,
      }
    end

    if policy(event).card_overview? || policy(event).card_grant_overview? || policy(event).transfers? || policy(event).reimbursements? || policy(event).employees?
      items << { section: "Spend" }
    end

    if policy(event).card_overview?
      items << {
        name: "Cards",
        path: event_cards_overview_path(event_id: event.slug),
        tooltip: "Manage team HCB cards",
        icon: "card",
        data: { tour_step: "cards" },
        selected: selected == :cards,
      }
    end

    if policy(event).card_grant_overview?
      items << {
        name: "Grants",
        path: event_card_grant_overview_path(event_id: event.slug),
        tooltip: "Manage card grants",
        icon: "bag",
        selected: selected == :card_grants
      }
    end

    if policy(event).transfers?
      items << {
        name: "Transfers",
        path: event_transfers_path(event_id: event.slug),
        tooltip: "Send & transfer money",
        icon: "payment-transfer",
        selected: selected == :transfers,
      }
    end

    if policy(event).reimbursements?
      items << {
        name: "Reimbursements",
        path: event_reimbursements_path(event_id: event.slug),
        async_badge: event_reimbursements_pending_review_icon_path(event),
        tooltip: "Reimburse team members & volunteers",
        icon: "reimbursement",
        selected: selected == :reimbursements
      }
    end

    if policy(event).employees?
      items << {
        name: "Contractors",
        path: event_employees_path(event_id: event.slug),
        tooltip: "Manage payroll",
        icon: "person-badge",
        selected: selected == :payroll
      }
    end

    if policy(event).team? || policy(event).promotions? || policy(event).g_suite_overview? || policy(event).documentation? || policy(event).sub_organizations?
      items << { section: "" }
    end

    if policy(event).team?
      items << {
        name: "Team",
        path: event_team_path(event_id: event.slug),
        tooltip: "Manage your team",
        icon: "people-2",
        selected: selected == :team,
      }
    end

    if policy(event).promotions?
      items << {
        name: "Perks",
        path: event_promotions_path(event_id: event.slug),
        tooltip: !policy(event).promotions? ? "Your account isn't eligble for receive promos & discounts" : "Receive promos & discounts",
        icon: "perks",
        data: { tour_step: "perks" },
        disabled: !policy(event).promotions?,
        selected: selected == :promotions,
      }
    end

    if policy(event).g_suite_overview?
      items << {
        name: "Google Workspace",
        path: event_g_suite_overview_path(event_id: event.slug),
        tooltip: (if !policy(event).g_suite_overview?
                    "Your organization isn't eligible for Google Workspace."
                  else
                    if event.g_suites.any?
                      "Manage domain Google Workspace"
                    else
                      Flipper.enabled?(:google_workspace, event) ? "Set up domain Google Workspace" : "Register for Google Workspace Waitlist"
                    end
                  end),
        icon: "google",
        disabled: !policy(event).g_suite_overview?,
        selected: selected == :google_workspace,
      }
    end

    if policy(event).documentation?
      items << {
        name: "Documents",
        path: event_documents_path(event_id: event.slug),
        tooltip: "View legal documents and financial statements",
        icon: "docs",
        selected: selected == :documentation,
      }
    end

    if policy(event).sub_organizations?
      items << {
        name: "Sub-organizations",
        path: event_sub_organizations_path(event_id: event.slug),
        tooltip: "Create & manage subsidiary organisations",
        icon: "channels",
        selected: selected == :sub_organizations
      }
    end

    items
  end

  def dock_item(name, url = nil, icon: nil, tooltip: nil, async_badge: nil, disabled: false, selected: false, admin: false, **options)
    icon_tag = icon.present? ? inline_icon(icon, size: 32) : nil
    badge_tag = async_badge.present? ? turbo_frame_tag(async_badge, src: async_badge, data: { controller: "cached-frame", action: "turbo:frame-render->cached-frame#cache" }) : nil

    icon_wrapper =
      if icon_tag || badge_tag
        content_tag(:div, class: "dock__item-icon-wrapper") do
          safe_join([icon_tag, badge_tag].compact)
        end
      end

    children = []
    children << icon_wrapper if icon_wrapper
    children << tag.span(name, class: "dock__item-label")
    children = safe_join(children)

    if admin && !auditor_signed_in?
      return ""
    end

    link_to children, (disabled ? "javascript:" : url), options.merge(
      class: "dock__item #{"tooltipped tooltipped--e" if tooltip} #{"disabled" if disabled} #{"admin-tools" if admin}",
      'aria-label': tooltip,
      'aria-current': selected ? "page" : "false",
      'aria-disabled': disabled ? "true" : "false",
    )
  end

  def show_mock_data?(event = @event)
    false
  end

  def paypal_transfers_airtable_form_url(embed: false, event: nil, user: nil)
    # The airtable form is located within the Bank Promotions base
    form_id = "4j6xJB5hoRus"
    embed_url = "https://forms.hackclub.com/t/#{form_id}"
    url = "https://forms.hackclub.com/t/#{form_id}"

    prefill = []
    prefill << "prefill_Event/Project+Name=#{CGI.escape(event.name)}" if event
    prefill << "prefill_Submitter+Name=#{CGI.escape(user.full_name)}" if user
    prefill << "prefill_Submitter+Email=#{CGI.escape(user.email)}" if user

    "#{embed ? embed_url : url}?#{prefill.join("&")}"
  end

  def transaction_memo(tx)
    # needed to handle mock data in playground mode
    if tx.local_hcb_code.method(:memo).parameters.size == 0
      tx.local_hcb_code.memo
    else
      tx.local_hcb_code.memo(event: @event)
    end
  end

  def humanize_audit_log_value(field, value)

    if field == "point_of_contact_id"
      return User.find(value).email
    end

    if field == "maximum_amount_cents"
      return render_money(value.to_s)
    end

    if field == "event_id"
      return Event.find(value).name
    end

    if field == "reviewer_id"
      return User.find(value).name
    end

    return "Yes" if value == true
    return "No" if value == false

    if field.ends_with?("_at")
      begin
        return local_time(value)
      rescue
        return value
      end
    end

    return value
  end

  def render_audit_log_field(field)
    field.delete_suffix("_cents").humanize
  end

  def render_audit_log_value(field, value, color:)
    return tag.span "unset", class: "muted" if value.nil? || value.try(:empty?)

    return tag.span humanize_audit_log_value(field, value), class: color
  end

  def show_org_switcher?
    signed_in? && current_user.events.not_hidden.count > 1
  end

  def check_filters?(filter_options, params)
    filter_options.any? do |opt|
      key = opt[:key].to_s

      case opt[:type]
      when "date_range"
        params["#{opt[:key_base]}_before"].present? || params["#{opt[:key_base]}_after"].present?
      when "amount_range"
        params["#{opt[:key_base]}_less_than"].present? || params["#{opt[:key_base]}_greater_than"].present?
      else
        params[key].present?
      end
    end
  end

  def validate_filter_options(filter_options, params)
    filter_options.each do |opt|
      case opt[:type]
      when "date_range"
        validate_date_range(opt[:key_base], params)
      when "amount_range"
        validate_amount_range(opt[:key_base], params)
      end
    end
  end

  def auto_discover_feed(event)
    if event.announcements.any?
      content_for :head do
        auto_discovery_link_tag :atom, event_feed_url(event, format: :atom), title: "Announcements for #{event.name}"
      end
    end
  end

  private

  def validate_date_range(base, params)
    less = params["#{base}_after"]
    greater = params["#{base}_before"]
    return unless less.present? && greater.present?

    begin
      less_date = Date.parse(less)
      greater_date = Date.parse(greater)
      if greater_date < less_date
        flash[:error] = "Invalid date range: 'after' date is greater than 'before' date"
      end
    rescue ArgumentError
      flash[:error] = "Invalid date format"
    end
  end

  def validate_amount_range(base, params)
    less = params["#{base}_less_than"]
    greater = params["#{base}_greater_than"]
    return unless less.present? && greater.present?

    if greater.to_f > less.to_f
      flash[:error] = "Invalid amount range: minimum is greater than maximum"
    end
  end

  def subevent_svg_graph(root, all_events)
    children_map = Hash.new { |h, k| h[k] = [] }
    event_map = all_events.index_by(&:id)

    all_events.each do |e|
      next if e.id == root.id
      children_map[e.parent_id] << e.id if event_map.key?(e.parent_id)
    end

    node_w = 180
    node_h = 36
    h_gap = 16
    v_gap = 64

    # Calculate subtree width in "slots" so we can center parents over children
    subtree_slots = {}
    calc_slots = lambda do |id|
      kids = children_map[id]
      subtree_slots[id] = kids.empty? ? 1 : kids.sum { |k| calc_slots.call(k) }
    end
    calc_slots.call(root.id)

    slot_width = node_w + h_gap
    positions = {}
    queue = [[root.id, 0, 0]]

    until queue.empty?
      id, level, left = queue.shift
      center_x = left + (subtree_slots[id] * slot_width - h_gap) / 2.0
      positions[id] = [center_x - node_w / 2.0, level * (node_h + v_gap)]
      child_left = left
      children_map[id].each do |kid|
        queue << [kid, level + 1, child_left]
        child_left += subtree_slots[kid] * slot_width
      end
    end

    xs = positions.values.map(&:first)
    ys = positions.values.map(&:last)
    min_x = xs.min
    offset_x = min_x < 10 ? (10 - min_x) : 0
    svg_w = (xs.max + node_w + offset_x + 20).ceil
    svg_h = (ys.max + node_h + 20).ceil

    parts = []
    parts << %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{svg_w} #{svg_h}" style="width:100%;height:auto;display:block;">)
    parts << %(<defs>)
    parts << %(<marker id="hcb-arr" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto"><polygon points="0 0, 8 3, 0 6" fill="#aaa" class="svg-arrow-head"/></marker>)
    parts << %(<style>)
    parts << %(.svg-edge{stroke:#aaa;stroke-width:2;fill:none})
    parts << %(.svg-node-child rect{fill:#fff;stroke:#ddd;stroke-width:1.5})
    parts << %(.svg-node-child text{fill:#1a1a1a;font-family:system-ui,-apple-system,sans-serif;font-size:13px})
    parts << %(.svg-node-root rect{fill:#ec3750;stroke:#c0392b;stroke-width:2})
    parts << %(.svg-node-root text{fill:#fff;font-family:system-ui,-apple-system,sans-serif;font-size:13px;font-weight:600})
    parts << %([data-dark='true'] .svg-node-child rect{fill:#2a2a2f;stroke:rgba(255,255,255,0.15)})
    parts << %([data-dark='true'] .svg-node-child text{fill:#e0e0e0})
    parts << %([data-dark='true'] .svg-edge{stroke:rgba(255,255,255,0.25)})
    parts << %([data-dark='true'] .svg-arrow-head{fill:rgba(255,255,255,0.25)})
    parts << %(</style>)
    parts << %(</defs>)

    # Edges
    positions.each do |id, (x, y)|
      rx = x + offset_x
      children_map[id].each do |kid|
        kx, ky = positions[kid]
        krx = kx + offset_x
        parts << %(<line class="svg-edge" x1="#{(rx + node_w / 2.0).round(1)}" y1="#{(y + node_h).round(1)}" x2="#{(krx + node_w / 2.0).round(1)}" y2="#{ky.round(1)}" marker-end="url(#hcb-arr)"/>)
      end
    end

    # Nodes
    positions.each do |id, (x, y)|
      event = event_map[id]
      rx = (x + offset_x).round(1)
      ry = y.round(1)
      is_root = id == root.id
      css_class = is_root ? "svg-node-root" : "svg-node-child"
      href = CGI.escapeHTML(is_root ? event_sub_organizations_path(root) : event_path(event))
      label = CGI.escapeHTML(event.name.to_s.truncate(24))
      cx = (rx + node_w / 2.0).round(1)
      cy = (ry + node_h / 2.0 + 4.5).round(1)
      title = CGI.escapeHTML(event.name.to_s)

      parts << %(<a href="#{href}" class="#{css_class}">)
      parts << %(<title>#{title}</title>)
      parts << %(<rect x="#{rx}" y="#{ry}" width="#{node_w}" height="#{node_h}" rx="18"/>)
      parts << %(<text x="#{cx}" y="#{cy}" text-anchor="middle">#{label}</text>)
      parts << %(</a>)
    end

    parts << %(</svg>)
    parts.join.html_safe
  end

end
