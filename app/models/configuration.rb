class Configuration < ApplicationRecord
  SECRET_SEGMENTS = /(?:^|_)(key|secret|token)(?:_|$)/i

  validates :name, presence: true, uniqueness: true

  # -- Hash-like class interface --

  def self.[](name)
    find_by(name: name)&.value
  end

  def self.fetch(name, *args, &block)
    name = name.to_s
    where(name:).pluck(:name, :value).to_h.fetch(name, *args, &block)
  end

  def self.values_at(*names)
    names = names.map(&:to_s)
    where(name: names).pluck(:name, :value).to_h.values_at(*names)
  end

  def self.fetch_values(*names, &block)
    names = names.map(&:to_s)
    where(name: names).pluck(:name, :value).to_h.fetch_values(*names, &block)
  end

  def self.each_pair(&block)
    return to_enum(:each_pair) unless block
    find_each { |config| block.call(config.name, config.value) }
  end

  def self.to_h
    pluck(:name, :value).to_h
  end

  def self.to_hash
    to_h
  end

  # -- Instance methods --

  def secret?
    SECRET_SEGMENTS.match?(name)
  end

  def display_value
    return value unless secret? && value.present? && value.length > 4

    "#{"*" * (value.length - 4)}#{value.last(4)}"
  end
end
