function Drow_3dsc(x,y,z,c,cl,ct)
xl = [0 9];
yl = [-3 3];
zl = [0 3];
tiledlayout(2,2);

%3D scatter
nexttile
scatter3(x,y,z,5,c,".")
xlabel("Range[m]")
ylabel("Azimuth[m]")
zlabel("Elevation[m]")
xlim(xl)
ylim(yl)
zlim(zl)
clim(cl)

%side scatter
nexttile
scatter(x,z,5,c,".")
xticks([0 3 6 9])
xlabel("Range[m]")
ylabel("Elevation[m]")
xlim(xl)

ylim(zl)
clim(cl)

%frant scatter
nexttile
scatter(y,z,5,c,"."); set(gca,'XDir','reverse');
xlabel("Azimuth[m]")
ylabel("Elevation[m]")
xlim(yl)
ylim(zl)
clim(cl)

%top scatter
nexttile
scatter(x,y,5,c,"."); axis xy;
%set(gca,'color',[0 0 0])
xticks([0 3 6 9])
xlabel("Range[m]")
ylabel("Azimuth[m]")
xlim(xl)

ylim(yl)
clim(cl)

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = ct;
