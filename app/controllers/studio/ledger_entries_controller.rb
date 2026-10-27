module Studio
  class LedgerEntriesController < BaseController
    def index
      entries = LedgerEntry.joins(:subscription).where(subscriptions: { plan_id: current_user.plans.select(:id) })
      @totals = entries.pick(*%i[gross_amount platform_fee creator_amount].map { |c| Arel.sql("COALESCE(SUM(#{c}), 0)") })
      @ledger_entries = entries.includes(subscription: %i[plan fan]).order(paid_at: :desc)
    end
  end
end
