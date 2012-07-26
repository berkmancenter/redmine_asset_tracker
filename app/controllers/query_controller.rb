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
    result = []
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
        #Find results for all custom attributes
        list_of_custom_attributes_id = Array.new
        keylist = params.keys

        keylist.each do |k|
          list_of_custom_attributes_id.push(k) if k.is_number? 
        end

        #Check for custom_attributes, this way gets a little ineffecient if we need to scale for thousands of assets
        Asset.find_each do |asset|
          
          is_result = true

          logger.info(asset.name)

          list_of_custom_attributes_id.each do |l|

            if asset.custom_value_for(l) == nil then
              is_result = false
              break
            end

            #if number compare directly
            if asset.custom_value_for(l).value.is_number? then
                unless asset.custom_value_for(l).value == params[l.to_sym]
                  is_result = false
                  break
                end
            else
                unless /[[:alnum:]]*#{params[l.to_sym].downcase}[[:alnum:]]*/.match(asset.custom_value_for(l).value.downcase) 
                  is_result = false
                  break
                end
            end

          end

          result.push(asset) if is_result
        end

        #check for fixed attributes
        result.each do |r|
          if (params[:name].blank? ||  /[[:alnum:]]*#{params[:name].downcase}[[:alnum:]]*/.match(r.name.downcase) ) && (params[:description].blank? ||  /[[:alnum:]]*#{params[:description].downcase}[[:alnum:]]*/.match(r.description.downcase) ) && (params[:asset_type].blank? ||  /[[:alnum:]]*#{params[:asset_type].downcase}[[:alnum:]]*/.match(r.asset_type.name.downcase) ) then
            @result_assets.push(r)
          end
        end
        logger.info(@result_assets)
    else
         #Get results from Asset Table for normal parameters
        @result_groups = AssetGroup.all(:conditions => [conditions, value])
    end
  end 
end