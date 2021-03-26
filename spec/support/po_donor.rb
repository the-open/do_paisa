module PODonationPayloads
  def debit_otg
    {
      'ReferenceNumber' => 'r2df2481-snmt-1afc-16e2-1k2fp19ueq3cg',
      'FirstName' => 'Heather',
      'LastName' => 'Smith',
      'StreetAddress' => '1101 Bloor St W',
      'City' => 'Toronto',
      'Province' => 'ON',
      'PostalCode' => 'M6H 1M7',
      'Phone' => '',
      'Email' => 'heather@example.ca',
      'BankINS' => '123',
      'BankTransit' => '00000',
      'BankAccount' => '123456',
      'PaymentMethod' => 'C',
      'GiftType' => 'OTG',
      'OTGAmount' => '1'
    }
  end

  def debit_recurring
    {
      'ReferenceNumber' => 'r2df2481-snmt-1afc-16e2-1k2fp19ueq3cg',
      'FirstName' => 'Heather',
      'LastName' => 'Smith',
      'StreetAddress' => '1101 Bloor St W',
      'City' => 'Toronto',
      'Province' => 'ON',
      'PostalCode' => 'M6H 1M7',
      'Phone' => '',
      'Email' => 'heather@example.ca',
      'BankINS' => '123',
      'BankTransit' => '00000',
      'BankAccount' => '123456',
      'PaymentMethod' => 'C',
      'GiftType' => 'PAC',
      'OTGAmount' => '1',
      'PACStartDate' => (DateTime.now + 15.days).strftime("%d/%m/%Y")
    }
  end

  def credit_otg
    {
      'ReferenceNumber' => 'r2df2481-snmt-1afc-16e2-1k2fp19ueq3cg',
      'FirstName' => 'Heather',
      'LastName' => 'Smith',
      'StreetAddress' => '1101 Bloor St W',
      'City' => 'Toronto',
      'Province' => 'ON',
      'PostalCode' => 'M6H 1M7',
      'Phone' => '',
      'Email' => 'heather@example.ca',
      'CARDNO' => '4242424242424242',
      'CCExpiry' => '10/2030',
      'PaymentMethod' => 'V',
      'GiftType' => 'OTG',
      'OTGAmount' => '5'
    }
  end

  def credit_recurring
    {
      'ReferenceNumber' => 'r2df2481-snmt-1afc-16e2-1k2fp19ueq3cg',
      'FirstName' => 'Heather',
      'LastName' => 'Smith',
      'StreetAddress' => '1101 Bloor St W',
      'City' => 'Toronto',
      'Province' => 'ON',
      'PostalCode' => 'M6H 1M7',
      'Phone' => '',
      'Email' => 'heather@example.ca',
      'CARDNO' => '4242424242424242',
      'CCExpiry' => '10/2030',
      'PaymentMethod' => 'M',
      'GiftType' => 'PAC',
      'OTGAmount' => '5',
      'PACStartDate' => (DateTime.now + 15.days).strftime("%d/%m/%Y")
    }
  end

  def upgrade
    {
      'ReferenceNumber' => 'r2df2481-snmt-1afc-16e2-1k2fp19ueq3cg',
      'FirstName' => 'Heather',
      'LastName' => 'Smith',
      'StreetAddress' => '1101 Bloor St W',
      'City' => 'Toronto',
      'Province' => 'ON',
      'PostalCode' => 'M6H 1M7',
      'Phone' => '',
      'Email' => 'heather@example.ca',
      'CARDNO' => '4242424242424242',
      'CCExpiry' => '10/2030',
      'PaymentMethod' => 'M',
      'GiftType' => 'UPG',
      'TotalAmount' => '10',
      'PACStartDate' => (DateTime.now + 15.days).strftime("%d/%m/%Y")
    }
  end
end
