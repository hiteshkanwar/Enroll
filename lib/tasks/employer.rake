namespace :broker do
  desc "Import Database"
  task :employer => :environment do
    Organization.all.destroy_all if Organization.all.count > 0
    (0..4).each_with_index do |org_index, index|
      organization = Organization.new(hbx_id: SecureRandom.hex(16), legal_name: Forgery('name').company_name, fein: SecureRandom.hex(4),is_active: 'true')
      organization.save(validate: false)

      broker_agency_profile_data = organization.build_broker_agency_profile(entity_kind: "s_corporation", market_kind: "both", languages_spoken: ["en"], working_hours: true, accept_new_clients: true, aasm_state: "is_approved")
      broker_agency_profile_data.save(validate: false)
    end

    Organization.all.collect(&:broker_agency_profile).each_with_index do |broker, index|
      (0..9).each do |employer_index|
        organization = Organization.new(hbx_id: SecureRandom.hex(16), legal_name: Forgery('name').company_name, fein: SecureRandom.hex(4),is_active: 'true')
        organization.save(validate: false)
      
        employer_profile = organization.build_employer_profile(entity_kind: "s_corporation", aasm_state: "applicant", profile_source: "self_serve")
        employer_profile.save(validate: false)
          employer_profile.broker_agency_accounts.build(broker_agency_profile: broker, writing_agent_id: nil, start_on: Date.today).save 
      end
    end

    employer_profiles = Organization.all.collect(&:employer_profile).compact

    employer_profiles.each_with_index do |employer, index|
      plan_year = employer.plan_years.build(start_on: BrokerAgencyProfile.time_rand_for_hire.to_date,end_on: BrokerAgencyProfile.time_rand_for_hire.to_date+1.year,open_enrollment_start_on: Date.today,open_enrollment_end_on: Date.today+1.year)
      plan_year.save(validate: false)
      plan_year.benefit_groups.build(title: 'test').save(validate: false)
      (1..20).each do |index|
        employee = employer.census_employees.new(first_name: Forgery('name').first_name, last_name: Forgery('name').last_name,dob: BrokerAgencyProfile.time_rand.to_date, hired_on: BrokerAgencyProfile.time_rand_for_hire.to_date,gender: Forgery('personal').gender, _type: "CensusEmployee",aasm_state: "eligible")
        employee.save(validate: false)
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
