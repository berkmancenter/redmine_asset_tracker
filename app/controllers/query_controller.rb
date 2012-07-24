class QueryController < ApplicationController
  unloadable

  def index
  	@available_custom_fields = AssetCustomField.all
  end

  def search

  end

end
