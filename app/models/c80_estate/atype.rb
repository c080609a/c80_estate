require "babosa"

module C80Estate

  class Atype < ActiveRecord::Base

    # http://stackoverflow.com/questions/9382708/rails-3-has-many-changed
    has_and_belongs_to_many :prop_names,
                            :join_table => 'c80_estate_atypes_prop_names',
                            :after_add => :after_add_prop_names,
                            :after_remove => :after_remove_prop_names

    has_many :areas, :dependent => :destroy
    has_many :properties, :dependent => :destroy
    has_many :atphotos, :dependent => :destroy   # одна или несколько фоток

    extend FriendlyId
    friendly_id :slug_candidates, :use => :slugged

    def slug_candidates
      [:title] + Array.new(6) {|index| [:title, index+2]}
    end

    def normalize_friendly_id(input)
      input.to_s.to_slug.normalize(transliterations: :russian).to_s
    end

    # • этот метод дёргает только StrsubcatSweeper
    # • после вызова метода - значение сбрасывается в false
    def prop_names_changed?
      res = @mark_prop_names_changed
      @mark_prop_names_changed = false
      res
    end

    def get_list_removed_props
      @list_removed_props = [] unless @list_removed_props.present?
      res = @list_removed_props
      @list_removed_props = []
      res
    end

    private

    # • Два метода after_add_prop_names и after_remove_prop_names
    # слушают изменения prop_names, и, при их наличии,
    # выставляют флаг mark_prop_names_changed в true.
    # • Этот флаг вертает обратно в false
    # метод after_update "чистильщика" StrsubcatSweeper.

    def after_add_prop_names(prop_name)
      unless new_record?
        puts "<Strsubcat.after_add_prop_names>: #{prop_name.title}"
        @mark_prop_names_changed = true
      end
    end

    def after_remove_prop_names(prop_name)
      puts "<Strsubcat.after_remove_prop_names>: #{prop_name.title}"
      @mark_prop_names_changed = true
      @list_removed_props = [] unless @list_removed_props.present?
      @list_removed_props << prop_name.id
    end

  end


end