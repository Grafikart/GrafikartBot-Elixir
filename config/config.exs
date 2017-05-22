use Mix.Config

config :discordbot,
  rss: "https://www.grafikart.fr/feed.rss",
  capslock: ":scream_cat: Pas la peine de hurler @user",
  empty_mention: ":robot: Merci de ne pas mentionner un autre utilisateur sans message @user",
  question: ":question: N'hésite pas à poser ta question directement @user, il n'est pas utile de demander si quelqu'un connait quelque chose avant.",
  filters_dm: """
:octagonal_sign: Votre message a été supprimé car il ne respecte pas le format imposé par le channel

```
@content
```
  """,
  code: [
    message: ":space_invader: Woops trop de code @user @link",
    dm: """
    Hey !

    Je viens de remarquer que tu as posté pas mal de code sur le chan Grafikart.

    Poster des gros morceaux de code n'est pas super pratique pour la lisibilité, aussi n'hésite pas à copier ton code sur un service tier comme hastebin.com.
    Tu peux optimiser tes chances d'avoir une réponse en utilisant ce template : http://hastebin.com/uzufecurol.php .

    ```
    @code
    ```
    """
  ],
  insults: [
    badwords: ~w(pute connard enculé bite ntm pd fdp tepu salope conasse iench pétasse catin bouffone bouffon truie),
    dm: """
    Hey ! pas d'insulte sur le chan, votre message a été supprimé :disappointed_relieved:
    ```
    @content
    ```
    """
  ],
  errors: [
    {~r/Cannot modify header information - headers already sent by/, "https://www.grafikart.fr/formations/deboguer-code-php/headers-already-sent"},
    {~r/Trying to get property of non-object /, "https://www.grafikart.fr/formations/deboguer-code-php/property-of-non-object"},
    {~r/Parse error: syntax error, unexpected /, "https://www.grafikart.fr/formations/deboguer-code-php/syntax-error"},
    {~r/ Undefined index: /, "https://www.grafikart.fr/formations/deboguer-code-php/undefined-index"}
  ],
  commands: [
    vague: """
:robot: Ta question est un peu trop vague @user.
Essaie de détailler un peu plus ta problématique (n'hésite pas à utiliser ce template : http://hastebin.com/uzufecurol.php).
    """,
    troll: "https://www.youtube.com/watch?v=VjA9uJ2dFCI",
    google: ":mag: @user Tu devrais trouver ton bonheur sur google https://www.google.fr/?gws_rd=ssl#q=@content",
    php: ":mag: @user Je pense que cette fonction devrait t'aider http://php.net/search.php?show=quickref&pattern=@content",
    grafikart: ":mag: @user Il y a surement déjà un tutoriel sur le sujet https://www.grafikart.fr/search?q=@content",
    code: """
:robot: N'hésite pas à mieux décrire ton problème @user. Si tu le souhaite tu peux utiliser ce template :
http://hastebin.com/uzufecurol.php
"""
  ],
  recast: %{
    api_down: "Je suis désolé mais mon cerveau n'est pas joignable actuellement",
    no_intent: "Je ne comprends pas votre demande, mais je vais m'améliorer !"
  },
  help: """
Voici la liste de mes commandes disponibles :

**help** : Affiche cette aide
**google** : Permet de renvoyer un utilisateur sur google, ex: "google @Grafikart#1849 grafikart.fr"
**grafikart** : Permet de renvoyer un utilisateur sur la recherche grafikart.fr, ex: "grafikart @Grafikart#1849 grafikart.fr"
**php** : Permet de renvoyer un utilisateur sur la doc de php, ex: "php @Grafikart#1849 grafikart.fr"
**code** : Permet d'indiquer à un utilisateur comment mieux poster sa question, ex: "code @Grafikart#1849"
**roles** : Permet de lister les différents rôle
**role** : Permet d'afficher le rôle, ex: "role BackEnd"
**rmrole** : Permet de retirer le rôle, ex: "rmrole BackEnd"

Un bug / un problème avec le bot ? https://github.com/Grafikart/GrafikartBot-Elixir/issues
""",
  roles: %{
    "fullstack" => "305381229753139200",
    "backend"   => "305381310996676609",
    "frontend"  => "305381272832704514",
    "devops"    => "305426040077942785",
    "designer"  => "305425719515938836",
    "freelance" => "305381504479920129",
    "etudiant"  => "305381380802609163"
  }

config :porcelain, goon_warn_if_missing: false

import_config "#{Mix.env}.exs"