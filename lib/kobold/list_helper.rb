class ListHelper
  def self.create_csv(list_of_hashes, sep=',', keys=nil)
    if keys.nil?
      keys = list_of_hashes[0].keys
    end

    csv = ''
   
    csv << keys.join(sep)
    csv << "\n"
    csv << list_of_hashes.map {|hash| keys.map {|key| hash[key]}.join(sep)}.join("\n")
    return csv
  end
end
