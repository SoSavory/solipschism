class MatchedAlias < ApplicationRecord

  belongs_to :alias_1, :class_name => "Alias"
  belongs_to :alias_2, :class_name => "Alias"

  def self.find_matches(alias_id, day)
    matches = self.where(effective_date: day).where(alias_1_id: alias_id).or(MatchedAlias.where(alias_2_id: alias_id)).pluck(:alias_1_id, :alias_2_id)
    matches.flatten!
    matches.delete(alias_id)
    matches.uniq!
    return matches
  end

  
end
