# Journal des changements

## 0.2.0 (18 novembre 2026)

- La documentation de chaque méthode liste les paramètres que l'API accepte, et lesquels sont obligatoires.
- Nouveau : `embedDomains`, pour les sites autorisés du paiement intégré.
- Nouveau : `MercyPayCatalog` (pays, opérateurs, types d'événements).
- Nouveau : `payments.waitForFinalStatus()` et `checkoutSessions.waitForCompletion()`.
- Nouveau : `testHelpers.mobileMoneyNumbers()` et `testHelpers.mobileMoneyNumber()`.

## 0.1.0 (16 novembre 2026)

- Première version : client, 70 opérations, pagination, erreurs typées, nouvelles tentatives et webhooks.
