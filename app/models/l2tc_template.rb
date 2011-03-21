class L2tcTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  belongs_to :shapeable_template, :polymorphic => true
  belongs_to :access_point_template

  # Template instances
  has_many :l2tcs, :dependent => :destroy

  somehow_has :many => :access_points, :through => :access_point_template

  # No outdating configuration logic here
  # l2tc has no attribute that could be outdate access points configuration...
  # (see ethernet, radio, tap, vlan and vap)

  def validate
    sum = 0
    self.shapeable_template.subinterfaces.each do |s|
      sum += s.output_band_percent unless s.output_band_percent.blank? or s.output_band_percent.nil?
    end
    if sum > 100
      errors.add_to_base(:Subinterface_percentage_sum_greater_than_100_perc)
      return false
    end

    if sum > 0 and (self.shapeable_template.output_band.blank? or self.shapeable_template.output_band.nil?)
      errors.add_to_base(:Interface_must_be_specified)
      return false
    end

    true
  end

end
