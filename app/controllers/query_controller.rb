# @author Nitish Upreti
class String
  def is_number?
    true if Float(self) rescue false
  end
end

class QueryController < ApplicationController
  unloadable

  def index
  	@available_custom_fields = AssetCustomField.all
  end

  def search
    #Get all the params in place, no field is mandatory

    conditions = []
    value = {}
    @result_assets = []
    @result_groups = []

    unless params[:name].blank?
       conditions << "name LIKE :name"
       value[:name] = "%#{params[:name]}%"
    end

    unless params[:description].blank?
        conditions << "description LIKE :description"
        value[:description] = "%#{params[:description]}%"
    end

    unless params[:asset_type].blank?
        conditions << "asset_type LIKE :asset_type"
        value[:asset_type] = "%#{params[:asset_type]}%"
    end

    conditions = conditions.join(" AND ")

    if params[:nature] == 'Asset' then
        @result_assets = Asset.all(:conditions => [conditions,value])
    else
         #Get results from Asset Table for normal parameters
        @result_groups = AssetGroup.all(:conditions => [conditions, value])
    end

  end 

end
