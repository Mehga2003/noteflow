from django.db import models


class Transaction(models.Model):

    TRANSACTION_TYPES = (

        ('income', 'Income'),

        ('expense', 'Expense'),
    )

    title = models.CharField(
        max_length=200
    )

    amount = models.FloatField()

    type = models.CharField(

        max_length=20,

        choices=TRANSACTION_TYPES
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    def __str__(self):

        return self.title