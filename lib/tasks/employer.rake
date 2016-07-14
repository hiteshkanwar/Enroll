namespace :broker do
  desc "Import Database"
  task :employer => :environment do
    (0..4).each do |org_index|
      organization = Organization.new(hbx_id: SecureRandom.hex(16), legal_name: "Organization "+org_index.to_s, fein: SecureRandom.hex(4))
      organization.save(validate: false)

      broker_agency_profile = organization.build_broker_agency_profile(entity_kind: "s_corporation", market_kind: "both", languages_spoken: ["en"], working_hours: true, accept_new_clients: true, aasm_state: "is_approved")
      broker_agency_profile.save(validate: false)

      employer_profile = organization.build_employer_profile(entity_kind: "s_corporation", aasm_state: "applicant", profile_source: "self_serve")
      employer_profile.save(validate: false)
    end

    broker_profiles = Organization.all.collect(&:broker_agency_profile).compact
    employer_profiles = Organization.all.collect(&:employer_profile).compact

    broker_profiles.each_with_index do |profile_index|
      employer_profiles.each do |employer|
        employer.broker_agency_accounts.build(broker_agency_profile: profile_index, writing_agent_id: nil, start_on: Date.today).save
      end
    end
    
    employer_profiles.each_with_index do |employer, index|
      (1..4).each do |index|
        person = Person.new( hbx_id: SecureRandom.hex(3), first_name: "person ", last_name: index.to_s, ssn: SecureRandom.hex(4)+index.to_s, dob: (Time.now.to_date - 20.year), gender: "male", is_tobacco_user: "unknown")
        person.save(validate: false)
        employee_role = person.employee_roles.create(employer_profile_id: employer.id, hired_on: Time.now, contact_method: "Only Paper communication", language_preference: "English")
      end
    end
  end
end
# run => rake broker:employer

# every organization has many brokers agency profiles

# every organization has many employer profile

# every employer profile can select multiple broker agency 

# employer broker association stored in broker agency account

# We need to get all employers for a broker agency profile

# We need to find all the employer profile with broker agency profile id

# @orgs = Organization.all.map{|org| org if (org.employer_profile.try(:broker_agency_accounts).present? )}.compact.flatten
# @orgs.where(broker_agency_profile_id: @broker_agency_profile._id)

# Organization.where(:'employer_profile.broker_agency_accounts' => {:$elemMatch => { is_active: true, broker_agency_profile_id: @id } }) 

# Organization.all.map{|org| org if (org.employer_profile.broker_agency_accounts.where(broker_agency_profile_id: @broker_agency_profile._id).first.present? rescue false)}
