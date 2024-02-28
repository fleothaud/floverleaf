export default [
  {
    type: 'cmd',
    label: '\\verb||',
    snippet: '\\verb|#{}|',
  },
  {
    type: 'cmd',
    label: '\\teX3R',
    snippet: '\\documentclass{classe-tex3R}\n\\usepackage{style-tex3R}\n\n\\begin{luacode}\n  Format = \'fiche\' --diapo/fiche\n  Chapitre = "" --nom du chapitre\n  Numero = \'\' --numéro du chapitre\n  Niveau = \'\' --niveau de classe\n\\end{luacode}\n\\parametrage\n%FIN PARAMÉTRAGE PRÉAMBULE\n\n\\begin{document}\n\n\\begin{luacode}\n  Type = \'basique\' --activite/bilan/corrige/cours/DM/DS/flash/interro/TD\n  Compteur = \'1\' --Numérotation de l\'entête\n  Impression = false --true\n  Header = false --true\n  Taille = nil --\'14pt\'\n  Stretch = false --true\n\n  Correction = false --true\n  Enonce = true --false\n  Visible = false --true\n\n  Competence = false --true\n  Bareme = false --true\n  Difficulte = false --true\n  Source = false --true\n  Theme = false --true\n\\end{luacode}\n\\parametrage\n%FIN PARAMÉTRAGE DOCUMENT\n\n%Le texte du document\n\n\\end{document}',
  },

]
