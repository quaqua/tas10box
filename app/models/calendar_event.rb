class CalendarEvent < Tas10::Document

  field :starts_at, :type => DateTime
  field :ends_at, :type => DateTime
  field :all_day, :type => Boolean, :default => false
  field :repeating_id, :type => Moped::BSON::ObjectId
  field :note
  field :location

  field :columns, :type => Array

  attr_accessor :starts_at_date, :starts_at_time, :ends_at_date, :ends_at_time
  before_save :setup_dates

  @@event_subclasses = []
  def self.event_subclasses
    @@event_subclasses
  end

  private

  def setup_dates
    if !starts_at_time.blank? && !starts_at_date.blank?
      self.starts_at = Time.parse( "#{starts_at_date} #{starts_at_time}" )
    end
    if !ends_at_time.blank? && !ends_at_time.blank?
      self.ends_at = Time.parse( "#{ends_at_date} #{ends_at_time}" )
    end
  end

  def self.inherited( subclass )
    @@event_subclasses << subclass.name unless @@event_subclasses.include? subclass.name
  end

end