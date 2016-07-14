namespace :broker do
  desc "Import Database"
  task :employer => :environment do
    (0..10).each do |profile_index|
      organization = Organization.new(hbx_id: SecureRandom.hex(16), legal_name: "Organization "+index.to_s, fein: SecureRandom.hex(4))

      organization.save(validate: false)

      broker_agency_profile = organization.build_broker_agency_profile(entity_kind: "s_corporation", market_kind: "both", languages_spoken: ["en"], working_hours: true, accept_new_clients: true, aasm_state: "is_approved")

      broker_agency_profile.save

      employer_profile = organization.build_employer_profile(entity_kind: "s_corporation", aasm_state: "applicant", profile_source: "self_serve")

      employer_profile.save

      (1..4).each do |index|
        person = Person.new( hbx_id: SecureRandom.hex(3), first_name: "person ", last_name: index.to_s, ssn: SecureRandom.hex(4)+index.to_s, dob: (Time.now.to_date - 20.year), gender: "male", is_tobacco_user: "unknown")
        person.save(validate: false)
        employee_role = person.employee_roles.create(employer_profile_id: employer_profile.id, hired_on: Time.now, contact_method: "Only Paper communication", language_preference: "English")
      end
    end
  end
end

# run => rake broker:employer