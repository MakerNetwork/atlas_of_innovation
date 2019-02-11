from django.db import models
from django.contrib.auth.models import User
from django_countries.fields import CountryField
from django.forms import ModelForm
from captcha.fields import ReCaptchaField
from django import forms
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils import six
from django.dispatch import receiver
from django.db.models.signals import post_save
from django.contrib.auth.forms import UserCreationForm
class Moderator(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    country = CountryField(max_length=20, null=True, blank=True)

class BasicUser(models.Model):
      user = models.OneToOneField(User, on_delete=models.CASCADE)
      email_confirmed = models.BooleanField(default=False)

@receiver(post_save, sender=User)
def update_user_profile(sender, instance, created, **kwargs):
    if created:
        BasicUser.objects.create(user=instance)
    instance.basicuser.save()
class UserForm(UserCreationForm):
    email=forms.EmailField(label='Your email', max_length=100)
    #country=CountryField(blank_label='(select country)').formfield()
    captcha = ReCaptchaField()
class Meta:
        model = User
        fields = ('username', 'email', 'password1', 'password2', )



class AccountActivationTokenGenerator(PasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        return (
            six.text_type(user.pk) + six.text_type(timestamp) +
            six.text_type(user.basicuser.email_confirmed)
        )

account_activation_token = AccountActivationTokenGenerator()


