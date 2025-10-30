from rest_framework import serializers
from .models import Password

class PasswordSerializer(serializers.ModelSerializer):
    # 'password' is a write-only field to receive the raw password from the user
    password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = Password
        fields = ['id', 'website', 'username', 'password']
        read_only_fields = ['id']

    def create(self, validated_data):
        """Encrypt the password on creation."""
        instance = Password(
            owner=validated_data['owner'],
            website=validated_data['website'],
            username=validated_data['username']
        )
        instance.set_password(validated_data['password'])
        instance.save()
        return instance

    def update(self, instance, validated_data):
        """Encrypt the password on update."""
        instance.website = validated_data.get('website', instance.website)
        instance.username = validated_data.get('username', instance.username)
        
        if 'password' in validated_data:
            instance.set_password(validated_data['password'])
            
        instance.save()
        return instance

class PasswordRetrieveSerializer(serializers.ModelSerializer):
    """Serializer to decrypt and show the password on retrieval."""
    password = serializers.SerializerMethodField()

    class Meta:
        model = Password
        fields = ['id', 'website', 'username', 'password']

    def get_password(self, obj):
        return obj.get_password()