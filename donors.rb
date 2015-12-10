require 'rubygems'
require 'httparty'
require 'csv'
require 'date'

loop do
  date = Date.today
  r = HTTParty.get("https://secure.candopolitics.com/tools/api/v2/ticker/66932941b0a2b7ce04620a2615d278f8604f6c20")
  summary_file = "csv/#{date.to_s.gsub('-','')}_summary.csv"
  donor_file = "csv/#{date.to_s.gsub('-','')}_donors.csv"
  if r.parsed_response
    begin
      f = File.open(summary_file)
      sh = f.size > 50 ? false : true
      f.close
    rescue
      sh = true
    end
    CSV.open(summary_file, "a+", :write_headers => sh, :headers => ['date','datetime','total_donors','total_amount','start']) do |row|
      row << [date.to_s, r.response['date'], r.parsed_response['total_donors'], r.parsed_response['total_amount'], r.parsed_response['start']]
    end
    begin
      f = File.open(donor_file)
      dh = f.size > 50 ? false : true
      f.close
    rescue
      dh = true
    end
    CSV.open(donor_file, "a+", :write_headers => dh, :headers => ['date','datetime','first_name','last_name','address']) do |row|
      r.parsed_response['recent_donors'].each do |recent_donor|
        row << [date.to_s, r.response['date'], recent_donor['first_name'], recent_donor['last_name'], recent_donor['address']]
      end
    end
  end
  sleep(60)
end
