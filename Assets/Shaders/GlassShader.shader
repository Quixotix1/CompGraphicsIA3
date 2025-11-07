Shader "Custom/GlassShader"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _NormalMap ("Normalmap", 2D) = "bump" {}
        _ScaleUV ("Scale", Range(1,20)) = 1
        _BumpExtrusion ("Bump Extrusion", Range(0, 0.1)) = 0.01  // Extrusion amount
        _FresnelIntensity ("Fresnel Intensity", Range(0, 2)) = 1
        _EmissionColor ("Emission Color", Color) = (0,0,0,0)
        _TintIntensity ("Tint Intensity", Range(1, 5)) = 1.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
                float2 uvbump : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float3 viewDirWS : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
            };

            // Declare texture and sampler variables for _BaseMap and _NormalMap
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;

            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            float4 _NormalMap_ST;

            TEXTURE2D(_GrabTexture);
            SAMPLER(sampler_GrabTexture);
            float4 _GrabTexture_TexelSize;

            float _ScaleUV;
            float _BumpExtrusion;  // Bump extrusion amount
            float _FresnelIntensity;
            float _TintIntensity;
            float4 _EmissionColor;

            // Vertex shader (extrusion based on vertex normal, not bump map)
            Varyings vert(Attributes v)
            {
                Varyings OUT;

                // Transform vertex to world space
                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = normalize(TransformObjectToWorldNormal(v.normal));

                // Extrude vertices along the original normals (simplified)
                worldPos += normalWS * _BumpExtrusion;  // Extrude along normal direction

                // Output the final vertex position in clip space
                OUT.vertex = TransformWorldToHClip(worldPos);

                #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
                #else
                float scale = 1.0f;
                #endif

                OUT.uvgrab.xy = (float2(OUT.vertex.x, OUT.vertex.y * scale) + OUT.vertex.w) * 0.5;
                OUT.uvgrab.zw = OUT.vertex.zw;
                OUT.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                OUT.uvbump = TRANSFORM_TEX(v.uv, _NormalMap);

                OUT.normalWS = normalWS;
                OUT.viewDirWS = normalize(_WorldSpaceCameraPos - worldPos);

                return OUT;
            }

            // Fragment shader
            half4 frag(Varyings i) : SV_Target
            {
                // Sample the normal map for lighting effects
                half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uvbump));
                float3 normalWS = normalize(normalTS + i.normalWS);

                // Fresnel effect
                float viewNormalDot = saturate(dot(i.viewDirWS, normalWS));
                float fresnelFactor = pow(1.0 - abs(viewNormalDot), _FresnelIntensity);

                // Sample grab texture and main texture
                half4 col = SAMPLE_TEXTURE2D(_GrabTexture, sampler_GrabTexture, i.uvgrab.xy / i.uvgrab.w);
                half4 tint = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);

                // Apply Fresnel effect and normal-based lighting to the color
                col.rgb += fresnelFactor * tint.rgb;

                // Apply tint with intensity factor
                col *= tint * _TintIntensity;

                // Apply emission
                col += _EmissionColor;

                // Gamma correction for vibrancy
                col.rgb = pow(col.rgb, 1.0 / 2.2);

                return col;
            }
            ENDHLSL
        }
    }
}