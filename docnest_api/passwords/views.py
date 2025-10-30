from rest_framework import viewsets, permissions
from .models import Password
from .serializers import PasswordSerializer, PasswordRetrieveSerializer

class PasswordViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Password.objects.filter(owner=self.request.user)

    def get_serializer_class(self):
        # Use a different serializer for retrieve actions to show decrypted password
        if self.action == 'retrieve':
            return PasswordRetrieveSerializer
        return PasswordSerializer

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)