class FavouritesController < ApplicationController
  unloadable

  def index 
  	@user = User.find_by_id session[:user_id]

    #no user signed up gives us a nil
    unless @user then
        render 'index'
        return
    end

    @assets=Array.new
    @asset_groups=Array.new

  	#For all the favourite enteries get the name of corresponding Assets
  	@user.favourites.each do |f|
  		if f.item_type=='AssetGroup'
  			asset_group=AssetGroup.find_by_id(f.item_id)
  			@asset_groups.push(asset_group)
  		else
  			asset=Asset.find_by_id(f.item_id)
  			@assets.push(asset)
  		end
  	end

  end

  def mark_as_favourite

  	@user = User.find_by_id session[:user_id]
  	@favourites=@user.favourites

  #Find if the item is already a favourite
	fav=Favourite.where(:item_id => params[:id], :item_type => params[:type], :user_id => session[:user_id])
	
  #unless we have an empty record
	unless fav.empty? then
		#un-favourite
		fav.first.destroy
	else
		#make it a favourite
		fav=Favourite.new
		fav.item_id=params[:id]
		fav.item_type=params[:type]
		fav.user_id=session[:user_id]
		fav.save
	end

	respond_to do |format|
		format.js
	end

  end

end
