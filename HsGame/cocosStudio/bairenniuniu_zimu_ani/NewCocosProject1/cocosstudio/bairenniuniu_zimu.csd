<GameFile>
  <PropertyGroup Name="bairenniuniu_zimu" Type="Scene" ID="a2ee0952-26b5-49ae-8bf9-4f1d6279b798" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="16" Speed="1.0000">
        <Timeline ActionTag="1567035196" Property="Position">
          <PointFrame FrameIndex="0" X="147.8913" Y="252.5803">
            <EasingData Type="0" />
          </PointFrame>
          <PointFrame FrameIndex="10" X="338.1978" Y="239.2408">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="1567035196" Property="Scale">
          <ScaleFrame FrameIndex="0" X="3.5000" Y="3.5001">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="10" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="12" X="1.0500" Y="1.0500">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="809143098" Property="Position">
          <PointFrame FrameIndex="16" X="349.1110" Y="239.6102">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="809143098" Property="Scale">
          <ScaleFrame FrameIndex="0" X="0.4000" Y="0.4000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="809143098" Property="BlendFunc">
          <BlendFuncFrame FrameIndex="0" Tween="False" Src="770" Dst="1" />
          <BlendFuncFrame FrameIndex="16" Tween="False" Src="770" Dst="1" />
        </Timeline>
        <Timeline ActionTag="-426875437" Property="Position">
          <PointFrame FrameIndex="16" X="341.0000" Y="237.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-426875437" Property="Scale">
          <ScaleFrame FrameIndex="0" X="0.3000" Y="0.3000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="16" X="0.2000" Y="0.2000">
            <EasingData Type="10" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-426875437" Property="BlendFunc">
          <BlendFuncFrame FrameIndex="0" Tween="False" Src="1" Dst="1" />
          <BlendFuncFrame FrameIndex="16" Tween="False" Src="770" Dst="1" />
        </Timeline>
      </Animation>
      <ObjectData Name="Scene" ctype="GameNodeObjectData">
        <Size X="1334.0000" Y="750.0000" />
        <Children>
          <AbstractNodeData Name="bg_1" CanEdit="False" ActionTag="1940242672" Tag="19" IconVisible="False" ctype="SpriteObjectData">
            <Size X="1334.0000" Y="750.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="667.0000" Y="375.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="Normal" Path="bg.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
          <AbstractNodeData Name="txt_bg_4" CanEdit="False" ActionTag="-1392542076" Tag="22" IconVisible="False" LeftMargin="243.5900" RightMargin="899.4100" TopMargin="496.3170" BottomMargin="218.6830" ctype="SpriteObjectData">
            <Size X="191.0000" Y="35.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="339.0900" Y="236.1830" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2542" Y="0.3149" />
            <PreSize X="0.1432" Y="0.0467" />
            <FileData Type="Normal" Path="txt_bg.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
          <AbstractNodeData Name="txt_WuHuaNiu_2" CanEdit="False" ActionTag="1567035196" Tag="20" IconVisible="False" LeftMargin="88.8913" RightMargin="1127.1086" TopMargin="477.4197" BottomMargin="232.5803" ctype="SpriteObjectData">
            <Size X="118.0000" Y="40.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="147.8913" Y="252.5803" />
            <Scale ScaleX="3.5000" ScaleY="3.5001" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.1109" Y="0.3368" />
            <PreSize X="0.0885" Y="0.0533" />
            <FileData Type="Normal" Path="txt_WuHuaNiu.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
          <AbstractNodeData Name="Particle_3" ActionTag="809143098" Tag="14" IconVisible="True" LeftMargin="349.1110" RightMargin="984.8890" TopMargin="510.3898" BottomMargin="239.6102" ctype="ParticleObjectData">
            <Size X="0.0000" Y="0.0000" />
            <AnchorPoint />
            <Position X="349.1110" Y="239.6102" />
            <Scale ScaleX="0.4000" ScaleY="0.4000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2617" Y="0.3195" />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="star_effect.plist" Plist="" />
            <BlendFunc Src="770" Dst="1" />
          </AbstractNodeData>
          <AbstractNodeData Name="Particle_1" ActionTag="-426875437" Tag="10" IconVisible="True" LeftMargin="341.0000" RightMargin="993.0000" TopMargin="513.0000" BottomMargin="237.0000" ctype="ParticleObjectData">
            <Size X="0.0000" Y="0.0000" />
            <AnchorPoint />
            <Position X="341.0000" Y="237.0000" />
            <Scale ScaleX="0.3000" ScaleY="0.3000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2556" Y="0.3160" />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="particle_texture.plist" Plist="" />
            <BlendFunc Src="1" Dst="1" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>