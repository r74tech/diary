import { readdir, readFile, writeFile } from "fs/promises";
import { join } from "path";
import matter from "gray-matter";
import { Resvg } from "@resvg/resvg-js";
import satori from "satori";
import { loadDefaultJapaneseParser } from "budoux";

const dir = "./_posts";
const parser = loadDefaultJapaneseParser();

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
  const wakachi = parser.parse(title);
  const svg = await satori(
    {
      type: "div",
      props: {
        style: {
          display: "flex",
          flexDirection: "column",
          backgroundColor: "#0f0d0e",
          width: "1200px",
          height: "630px",
          padding: "80px",
        },
        className: "wrapper",
        children: [
          {
            type: "div",
            props: {
              style: {
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              },
              className: "top",
              children: [
                {
                  type: "div",
                  props: {
                    style: {
                      display: "flex",
                      fontSize: "32px",
                      fontFamily: "Fira Code",
                      color: "#f9f4da",
                    },
                    children: [
                      {
                        type: "span",
                        props: {
                          style: {
                            color: "#0ba95b",
                            paddingRight: "16px",
                          },
                          children: [">"],
                        },
                      },
                      "pnpm i @r74tech/blog",
                    ],
                  },
                },
              ],
            },
          },
          {
            type: "div",
            props: {
              style: {
                display: "flex",
                flexDirection: "column",
                justifyContent: "flex-end",
                flexBasis: "100%",
                width: "90%",
                paddingBottom: "40px",
              },
              className: "bottom",
              children: [
                {
                  type: "div",
                  props: {
                    style: {
                      display: "flex",
                      marginTop: "16px",
                      fontSize: "64px",
                      fontFamily: "Zen Kaku Gothic New",
                      fontWeight: "400",
                      color: "#12b5e5",
                      wordBreak: "auto-phrase",
                    },
                    className: "title",
                    children: [wakachi]
                  },
                },
                {
                  type: "div",
                  props: {
                    style: {
                      display: "flex",
                      marginTop: "16px",
                      color: "#f9f4da",
                      fontFamily: "Outfit",
                      fontSize: "40px",
                      fontWeight: "400",
                    },
                    className: "description",
                    children: [description],
                  },
                },
              ],
            },
          }
        ]
      }
    },
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
          name: "Outfit Bold",
          data: await readFile(
            new URL("./assets/fonts/outfit-bold.ttf", import.meta.url)
          ),
          weight: "700",
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
  console.log("✅", slug);
}
