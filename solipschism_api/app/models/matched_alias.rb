class MatchedAlias < ApplicationRecord

  belongs_to :alias
  belongs_to :matched_alias, class_name: "Alias"

  after_create :create_inverse, unless: :has_inverse?
  after_destroy :destroy_inverses, if: :has_inverse?

  def create_inverse
    self.class.create(inverse_match_options)
  end

  def destroy_inverses
    inverses.destroy_all
  end

  def has_inverse?
    self.class.exists?(inverse_match_options)
  end

  def inverse_match_options
    self.class.where(inverse_match_options)
  end

  def inverse_match_options
    { matched_alias_id: alias_id, alias_id: matched_alias_id, effective_date: Date.today}
  end

end
