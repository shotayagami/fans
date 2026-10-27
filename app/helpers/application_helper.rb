module ApplicationHelper
  def yen(amount)
    number_to_currency(amount, unit: "¥", precision: 0, format: "%u%n")
  end

  def subscription_status_label(subscription)
    { "active" => "加入中", "trialing" => "お試し中", "past_due" => "支払い遅延", "canceled" => "解約済み" }
      .fetch(subscription.status, subscription.status)
  end
end
