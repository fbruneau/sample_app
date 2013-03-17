Factory.define :user do |user|
  user.nom                  "James Bond"
  user.email                 "007@mi6.uk"
  user.password              "moneypenny"
  user.password_confirmation "moneypenny"
	user.taille								 "1.70"
	user.poidactu							 "60"
	user.poidideal 						 "59"
	user.dob								DateTime.now
end

