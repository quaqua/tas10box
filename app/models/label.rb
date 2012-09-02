class Label < Tas10::Document

  field :color, :type => String
  field :template, :type => String
  field :labelable, :type => Boolean, :default => true

  field :columns, :type => Array, :default => []

end
