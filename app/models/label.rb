class Label < Tas10::Document

  field :color, :type => String
  field :template, :type => String
  field :labelable, :type => Boolean, :default => true

  field :settings, :type => Hash, :default => {}

  field :columns, :type => Array, :default => []
  field :as_checkbox, :type => Boolean, :default => false

  index as_checkbox: 1

end
