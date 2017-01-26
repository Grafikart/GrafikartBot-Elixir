# Discordbot

[![Build Status](https://travis-ci.org/Grafikart/GrafikartBot-Elixir.svg)](https://travis-ci.org/Grafikart/GrafikartBot-Elixir)

Code utilisé pour gérer le bot sur le channel discord de Grafikart.fr

## Pourquoi Elixir ?

Le bot a été développé en utilisant Elixir car je souhaitais apprendre ce langage et l'expérimenter
à travers un exemple concret. Le principal avantage est ici l'utilisation d'OTP qui permet
au bot de se relancer automatiquement en cas d'erreur mais aussi de gérer les appels à l'API discord
sur un process séparé pour une meilleur réactivité.

```bash
# Démarrer le bot
git pull origin master && MIX_ENV=prod mix release && _build/prod/rel/discordbot/bin/discordbot restart
```
## Envie de participer ?

Ce code n'a pas pour but d'être générique et de convenir à un autre chanel que Grafikart.fr mais
si vous avez des idées qui pourraient améliorer le fonctionnement n'hésitez pas à créer une issue ou faire une PR

## Todo

  - Chercher un site "à la" codeshare.io avec une API pour copier le code plus facilement
  - Permettre au bot de répondre à des messages privés humains "Quand est le prochain live ? Quand est le prochain tutos..."