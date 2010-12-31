BRAND = "Hackadactyl"
COMPANY = "Hackadactyl"
WEBSITE = "hackadactyl.com"

SUPPORT_EMAIL = "support@hackadactyl.com"

SYSTEM_EMAIL =  'support@hackadactyl.com'
INFO_EMAIL =  [BRAND, '<support@hackadactyl.com>']
DEVELOPER_EMAIL = %("Kevin Skoglund" <matt@novafabrica.com>)

STANDARD_EMAIL_REGEX = /^([a-z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-z0-9\-]+\.)+))([a-z]{2,4}|[0-9]{1,3})(\]?)$/i

Time::DATE_FORMATS[:standard] = "%B %e, %Y at %l:%M %p %Z"
Time::DATE_FORMATS[:date_only] = "%B %e, %Y"
Date::DATE_FORMATS[:standard] = "%B %e, %Y"


