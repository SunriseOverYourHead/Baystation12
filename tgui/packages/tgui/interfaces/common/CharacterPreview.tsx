import { useEffect, useState } from 'react';
import { ByondUi } from 'tgui-core/components';

function CharacterPreviewImg(props: Readonly<{
  width: string;
  height: string;
  id: string;
}>) {
  const { width, height, id } = props;
  const [shownId, setShownId] = useState(id);

  useEffect(() => {
    if (id === shownId) return;
    let cancelled = false;
    let retries = 0;

    const tryLoad = () => {
      const img = new globalThis.Image();
      img.onload = () => {
        if (!cancelled) setShownId(id);
      };
      img.onerror = () => {
        if (cancelled) return;
        if (retries++ < 8) {
          setTimeout(tryLoad, 250);
        } else {
          setShownId(id);
        }
      };
      img.src = id;
    };

    tryLoad();
    return () => {
      cancelled = true;
    };
  }, [id, shownId]);

  return (
    <img
      alt=""
      src={shownId}
      style={{
        width,
        height,
        objectFit: 'contain',
        display: 'block',
        backgroundColor: 'black',
      }}
    />
  );
}

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string;
}) => {
  const { width = '220px', height, id } = props;
  if (id?.endsWith('.png')) {
    return <CharacterPreviewImg width={width} height={height} id={id} />;
  }
  return (
    <ByondUi
      width={width}
      height={height}
      params={{
        id,
        type: 'map',
      }}
    />
  );
};
