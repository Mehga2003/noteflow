from rest_framework import serializers

from .models import (
    Note,
    Transaction
)


# =========================================
# NOTE SERIALIZER
# =========================================

class NoteSerializer(

    serializers.ModelSerializer
):

    class Meta:

        model = Note

        fields = '__all__'

        read_only_fields = ['user']


# =========================================
# TRANSACTION SERIALIZER
# =========================================

class TransactionSerializer(

    serializers.ModelSerializer
):

    class Meta:

        model = Transaction

        fields = '__all__'

        read_only_fields = ['user']