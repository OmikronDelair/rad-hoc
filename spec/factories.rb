FactoryGirl.define do
  factory :album do
    title "Some Album"
    performer
  end

  factory :track do
    title "Some Track"
    track_number 5
    album
  end

  factory :performer do
    title "Dr."
    name "Ron Paul"
  end
end
