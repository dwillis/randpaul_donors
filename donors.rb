require 'rubygems'
require 'httparty'
require 'csv'
require 'date'

loop do
  date = Date.today
  r = HTTParty.get("https://secure.randpaul.com/ticker/ticker.php", headers: {"User-Agent" => "Pro Publica"})
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
    system 'git add csv/'
    system "git commit -m 'updated from #{r.response['date']}'"
    system 'git push origin master'
  end
  sleep(60)
end
