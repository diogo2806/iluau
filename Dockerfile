FROM node:20-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production

COPY plugins/iluau ./plugins/iluau

CMD ["node", "plugins/iluau/server/index.js"]
