# @author Nitish Upreti
class PluginController < ApplicationController

	#shared methods to be put in PluginController

	def populate_asset_list
    	
    	assets=Array.new
    	asset_groups=Array.new

      @user= User.find_by_id session[:user_id]

      	#For all the favourite enteries get the name of corresponding Assets
     	 @user.favourites.each do |f|
        	if f.item_type=='AssetGroup'
          		asset_group=AssetGroup.find_by_id(f.item_id)
          		asset_groups.push(asset_group)
        	else
          		asset=Asset.find_by_id(f.item_id)
          		assets.push(asset)
        	end
      	end

      	[assets,asset_groups]
 	end

 	def populate_favourite_list
        	
        	favourites_asset_group=Array.new
        	favourites_asset=Array.new

          @user= User.find_by_id session[:user_id]
    
       		@user.favourites.each do |f|
          
           		 if f.item_type=='AssetGroup' then
                	asset_group=AssetGroup.find_by_id(f.item_id)
                	favourites_asset_group.push(asset_group.id)
            	else
                	asset=Asset.find_by_id(f.item_id)
                	favourites_asset.push(asset.id)
            	end
       		end

       		[favourites_asset,favourites_asset_group]

 	end
end