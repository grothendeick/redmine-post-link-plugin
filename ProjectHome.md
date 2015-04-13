**This project has moved to [Github](https://github.com/Polidea/redmine-post-link-plugin).**


This plugin enables Redmine to fill the content of 'New Issue' form with GET parameters passed in the URL.

# Installation #
Unzip the archive and place it redmine/vendor/plugins directory and restart Redmine.
After restart the plugin should be listed http://your-domain:redmine_port/admin/plugins

# Usage #
Plugin needs per project enabling. To do so simply go to: Your Project->Settings->Modules and check the "Issues through get" checkbox.

After above modification you should be able to redirect the user to a prefilled "new issue" form using following url:

http://your-domain:redmine_port/postlink/new?project_id=XXX

Where XXX is your project's ID.
Following additional GET parameters are handled:
  * subject - the subject of the new issue
  * description - description of the new message
  * email - the email of the user (registered in redmine) to whom the issue is to be
assigned

# Example #
Following URL will display a filled 'new issue' form in Redmine:
```
http://127.0.0.1:3000/postlink/new?project_id=testapplication&subject=test&description=test%20description&email=piotrek%40gmail.com
```