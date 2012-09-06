class CalendarEvent < Tas10::Document

  field :starts_at, :type => DateTime
  field :ends_at, :type => DateTime
  field :note
  field :location

end