from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PasswordViewSet

router = DefaultRouter()
router.register(r'passwords', PasswordViewSet, basename='password')

urlpatterns = [
    path('', include(router.urls)),
]