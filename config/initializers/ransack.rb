Ransack.configure do |config|
  config.add_predicate "usage_date_gteq",
    arel_predicate: "gteq",
    formatter: proc { |v| v.to_date },
    validator: proc { |v| v.present? },
    type: :date,
    compounds: true,
    aliases: [ "cycles_created_at_gteq" ]

  config.add_predicate "usage_date_lteq",
    arel_predicate: "lteq",
    formatter: proc { |v| v.to_date },
    validator: proc { |v| v.present? },
    type: :date,
    compounds: true,
    aliases: [ "cycles_created_at_lteq" ]
end
