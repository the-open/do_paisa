require 'rails_helper'
require Rails.root.join 'spec', 'support', 'po_donor.rb'
include PODonationPayloads

RSpec.describe PODonationDataProcessor do
  describe '#process' do
    before do
      startdate = (DateTime.now + 40.days).strftime("%d/%m/%Y")
      @stripe_processor = FactoryBot.create(:stripe_processor)
      @stripe_processor.update(api_secret: ENV['STRIPE_SECRET_KEY'])
      @iats_processor = FactoryBot.create(:iats_processor)
      @po_processor = PODonationDataProcessor.new
    end

    context 'creates OTGs' do
      it 'creates a debit OTG' do
        payload = debit_otg()

        result = @po_processor.process(payload)
        donor = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @iats_processor.id).first
        transaction = Transaction.find_by(donor_id: donor.id)

        expect(donor).to be_present
        expect(donor.recurring_donor).to be_nil
        expect(transaction).to be_present
        expect(transaction.amount).to eq 100
        expect(transaction.status).to eq 'pending'
      end

      it 'creates a CC OTG' do
        payload = credit_otg()

        result = @po_processor.process(payload)
        donor = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @stripe_processor.id).first
        transaction = Transaction.find_by(donor_id: donor.id)

        expect(donor).to be_present
        expect(donor.recurring_donor).to be_nil
        expect(transaction).to be_present
        expect(transaction.amount).to eq 500
        expect(transaction.status).to eq 'approved'
      end
    end

    context 'creates recurring donations' do
      it 'creates a debit recurring donation' do
        payload = debit_recurring()

        result = @po_processor.process(payload)
        donor = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @iats_processor.id).first
        recurring_donor = RecurringDonor.find_by(donor_id: donor.id)
        transaction = Transaction.find_by(donor_id: donor.id)

        expect(donor).to be_present
        expect(recurring_donor).to be_present
        expect(recurring_donor.next_charge_at).to eq Date.today + 15.days
        expect(transaction).to be_nil
      end

      it 'creates a cc recurring donation' do
        payload = credit_recurring()

        result = @po_processor.process(payload)
        donor = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @stripe_processor.id).first
        recurring_donor = RecurringDonor.find_by(donor_id: donor.id)
        transaction = Transaction.find_by(donor_id: donor.id)

        expect(donor).to be_present
        expect(recurring_donor).to be_present
        expect(recurring_donor.next_charge_at).to eq Date.today + 15.days
        expect(transaction).to be_nil
      end
    end

    context 'upgrades' do
      it 'upgrades an existing donation' do
        payload = credit_recurring()

        result = @po_processor.process(payload)

        payload = upgrade()

        result = @po_processor.process(payload)

        donor = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @stripe_processor.id).first
        recurring_donor = RecurringDonor.find_by(donor_id: donor.id)

        expect(Donor.count).to eq 1
        expect(donor).to be_present
        expect(recurring_donor).to be_present
        expect(recurring_donor.amount).to eq 1000
      end
      it 'creates a new donation if upgrade payment type is different' do
        payload = debit_recurring()

        result = @po_processor.process(payload)

        payload = upgrade()

        result = @po_processor.process(payload)

        donor_one = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @iats_processor.id).first
        recurring_donor_one = RecurringDonor.find_by(donor_id: donor_one.id)

        donor_two = Donor.where("metadata ->> 'email' = ?", payload['Email']).where(processor_id: @stripe_processor.id).first
        recurring_donor_two = RecurringDonor.find_by(donor_id: donor_two.id)

        expect(Donor.count).to eq 2
        expect(donor_one).to be_present
        expect(recurring_donor_one).to be_present
        expect(recurring_donor_one.ended_at).not_to be_nil
        expect(donor_two).to be_present
        expect(recurring_donor_two).to be_present
        expect(recurring_donor_two.ended_at).to be_nil
        expect(recurring_donor_two.amount).to eq 1000
      end
    end

  end
end
