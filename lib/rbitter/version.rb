module Rbitter
  PRODUCT_NAME = "Rbitter"
  VERSION = "0.2.4"

  def major
    VERSION.match(/^([0-9]+)\./)[1]
  end

  def minor
    VERSION.match(/\.([0-9]+)\./)[1]
  end

  def patchlv
    VERSION.match(/\.([0-9]+)$/)[1]
  end

  def version_string
    "#{PRODUCT_NAME} #{VERSION}"
  end
end
