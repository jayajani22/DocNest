from django.db import models
from django.conf import settings
from cryptography.fernet import Fernet

# Get the encryption key from settings
fernet = Fernet(settings.ENCRYPTION_KEY)

class Password(models.Model):
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='passwords')
    website = models.CharField(max_length=255)
    username = models.CharField(max_length=255)
    password_encrypted = models.TextField() # Store encrypted password

    def set_password(self, raw_password):
        self.password_encrypted = fernet.encrypt(raw_password.encode()).decode()

    def get_password(self):
        return fernet.decrypt(self.password_encrypted.encode()).decode()

    def __str__(self):
        return self.website