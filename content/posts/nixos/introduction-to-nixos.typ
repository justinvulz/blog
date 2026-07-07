#import "/templates/post.typ": post, img, columns

#let args = (
  title: "Nix 和 NixOS 介紹",
  date: "2026-07-06",
  author: "Justin",
  tags: ("Nix","NixOS"),
  order: 1,
)

#show: post.with(..args)


我目前已經使用 NixOS 作爲日常生活、娛樂、工作的主力系統兩年左右。
雖然官方有文檔，現在也有許多教學文章和影片，
但 NixOS 對於一班使用者來說，還是一個學習曲線非常陡峭的一個Linux Distribution。
所以我打算為中文社區貢獻一點微薄之力。

在本站更新的 NixOS 教學將以我日常使用的實踐和心得，盡量簡單的讓初學者可以簡單上手。


= What is Nix and NixOS

Nix 是一個funtional programming language。
有點像是 Haskell ，這類語言強調的是 pure function，也就是函數在相同的輸入下會有一樣的輸出。
Nix package manager 是使用 Nix 作爲語言的包管理器。
而 NixOS 就是使用 Nix packge manager 的作業系統（ 像是 apt in Debian, pacman in Arch ）。

然而 Nix 可不止 是一般的包管理器，除了安裝軟體外，還能夠管理各種不同程式的 Config 檔案和各種 System 的設定， 
包括 network, hardware, filesystem, booting, ...。
在 NixOS 中 這些 config 會用 Nix language 寫成， 記錄在電腦裡面。

以上性質引出一個最重要的特性： Reproducible， 只要 有 config 就算電腦重灌，還是能完整復原。
同時因爲所有設定和軟體安裝都是寫在檔案裡的，因此我們課以很簡單的檢查我們裝了什麼、改了什麼設定。

