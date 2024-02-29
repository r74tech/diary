---
title: OG画像を動的に生成する
author: r74tech
categories:
  - web
tags:
  - js
  - front
math: false
mermaid: false
slug: 2024-02-29-generate-og
image:
  path: ./assets/img/og/2024-02-29-generate-og.png
  show: false
---

## 動的にOG画像を生成する

Twitterでよく技術系記事を自サイトでホストしている人達は華やかなOG画像を載せているように思える。実際、リンクを共有したときに表示されるのであれば記事の内容が一目でわかりとても良いと思われる。

このサイトはJekyllで生成されるため、記事の内容を元にOG画像を生成すると処理が重くなる。そこで、記事のタイトルなどfrontmatterを元にOG画像を生成する方法を考えた。

## 環境
```
@resvg/resvg-js 2.6.0
gray-matter 4.0.3
satori 0.10.13
satori-html 0.3.2
```

## 実装

markdownファイルは以下のように、frontmatterを事前に設定しておく。

```md
---
title: sample
slug: 2024-02-29-sample
tags:
  - sample
  - test

---
```
slugは記事のURLになる他、OG画像のファイル名にもなる。また、tagsはOG画像の説明に使う。

以下のスクリプトは、_postsディレクトリにあるファイルを読み込み、frontmatterを元にOG画像を生成する。
<details>
<summary>generate-og.js</summary>

```js
import { readdir, readFile, writeFile } from "fs/promises";
import { join } from "path";
import matter from "gray-matter";
import { Resvg } from "@resvg/resvg-js";
import { html } from "satori-html";
import satori from "satori";

const dir = "./_posts";
try {
  const files = await readdir(dir);
  for (const file of files) {
    const content = await readFile(join(dir, file), "utf8");
    const result = matter(content);
    await generateOgImage({
      title: result.data.title,
      slug: result.data.slug.toLowerCase(),
      description: result.data.tags ? result.data.tags.join(", ") : "",
    });
  }
} catch (err) {
  console.error("Error:", err);
}


async function generateOgImage({ title, slug, description }) {
  const svg = await satori(
    html`
      <style>
        div {
          display: flex;
        }

        .wrapper {
          display: flex;
          flex-direction: column;
          background-color: #0f0d0e;
          height: 630px;
          padding: 80px;
        }

        .top {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .bottom {
          display: flex;
          flex-direction: column;
          justify-content: flex-end;
          flex-basis: 100%;
          width: 90%;
          padding-bottom: 40px;
        }

        .install {
          font-size: 32px;
          font-family: "Fira Code";
          color: #f9f4da;
        }

        .install span {
          color: #0ba95b;
          padding-right: 16px;
        }

        .title {
          margin-top: 16px;
          font-size: 64px;
          font-family: "Zen Kaku Gothic New";
          font-weight: 400;
          color: #12b5e5;
          word-break: auto-phrase;
        }

        .description {
          margin-top: 16px;
          color: #f9f4da;
          font-family: "Outfit";
          font-size: 40px;
          font-weight: 400;
        }
      </style>
      <div class="wrapper">
        <div class="top">
          <div class="install"><span>></span> pnpm i @r74tech/blog</div>
        </div>
        <div class="bottom">
          <div class="title">${title}</div>
          <div class="description">${description}</div>
        </div>
      </div>`,
    {
      fonts: [
        {
          name: "Outfit",
          data: await readFile(
            new URL("./assets/fonts/outfit-regular.ttf", import.meta.url)
          ),
          weight: "400",
          style: "normal",
        },
        {
          name: "Fira Code",
          data: await readFile(
            new URL("./assets/fonts/firacode-regular.ttf", import.meta.url)
          ),
          weight: "400",
          style: "normal",
        },
        {
          name: "Zen Kaku Gothic New",
          data: await readFile(
            new URL("./assets/fonts/ZenKakuGothicNew-Regular.ttf", import.meta.url)
          ),
          weight: "400",
          style: "normal",
        }
      ],
      width: 1200,
      height: 630,
    }
  );

  const resvg = new Resvg(svg, {
    fitTo: {
      mode: "original",
    },
  });
  const pngData = resvg.render();
  const pngBuffer = pngData.asPng();
  await writeFile(
    new URL(`./assets/img/og/${slug}.png`, import.meta.url),
    pngBuffer
  );
}

```
</details>

![生成画像](https://blog.r74.tech/assets/img/post/2024-02-29/2024-02-29-generate-og.png)


## Jekyll側の対応
このブログのテーマ側で、`jekyll-seo-tag`が使われているため、frontmatterに`image`を追加することでOG画像を指定できる。ただし、画像を追加すると記事の初めに画像が表示されるため、`_layouts/post.html`を修正する必要がある。

```diff
{% if page.image %}
+ {% if page.image.show %}
    {% capture src %}src="{{ page.image.path | default: page.image }}"{% endcapture %}
    {% capture class %}class="preview-img{% if page.image.no_bg %}{{ ' no-bg' }}{% endif %}"{% endcapture %}
    {% capture alt %}alt="{{ page.image.alt | xml_escape | default: "Preview Image" }}"{% endcapture %}

    {% if page.image.lqip %}
      {%- capture lqip -%}lqip="{{ page.image.lqip }}"{%- endcapture -%}
    {% endif %}

    <div class="mt-3 mb-3">
      <img {{ src }} {{ class }} {{ alt }} w="1200" h="630" {{ lqip }}>
      {%- if page.image.alt -%}
        <figcaption class="text-center pt-2 pb-2">{{ page.image.alt }}</figcaption>
      {%- endif -%}
    </div>
+ {% endif %}
{% endif %}
```

このブログでは、`show`を追加してOG画像を表示するかどうかを指定できるようにした。


## 参考文献

- [HonoXでsatoriを使ってOGイメージもSSGする](https://blog.berlysia.net/entry/2024-02-29-honox-og-image)
