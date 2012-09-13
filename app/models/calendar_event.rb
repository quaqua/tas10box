class CalendarEvent < Tas10::Document

  field :starts_at, :type => DateTime
  field :ends_at, :type => DateTime
  field :all_day, :type => Boolean, :default => false
  field :repeating_id, :type => Moped::BSON::ObjectId
  field :note
  field :location

  attr_accessor :starts_at_date, :starts_at_time, :ends_at_date, :ends_at_time

  @@event_subclasses = []
  def self.event_subclasses
    @@event_subclasses
  end

  private

  def self.inherited( subclass )
    @@event_subclasses << subclass.name unless @@event_subclasses.include? subclass.name
  end

end