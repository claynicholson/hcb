# frozen_string_literal: true

class AddStripeCardsAndReimbursementReportsEnabledToCardGrants < ActiveRecord::Migration[7.2]
  def change
    add_column :card_grants, :stripe_cards_enabled, :boolean
    add_column :card_grants, :reimbursement_reports_enabled, :boolean
  end
end
