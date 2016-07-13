namespace :broker do
  desc "Import Database"
  task :employer => :environment do
    BrokerAgencyProfile.all.each do |broker_agency_profile|

      Organization.all.each do |org|
        employer_profile = org.build_employer_profile(entity_kind: "s_corporation", aasm_state: "applicant", profile_source: "self_serve")
        employer_profile.save

        [1..4].each do |index|
          person = Person.new( hbx_id: SecureRandom.hex(3), first_name: "person "+broker_agency_profile.id.to_s.first, last_name: "name "+index.to_s, ssn: SecureRandom.hex(4)+index.to_s, dob: (Time.now.to_date - 20.year), gender: "male", is_tobacco_user: "unknown")
          person.save(validate: false)
          employee_role = person.employee_roles.create(employer_profile_id: employer_profile.id, hired_on: Time.now, contact_method: "Only Paper communication", language_preference: "English")
        end
      end
    end
  end
end
# run => rake broker:employer